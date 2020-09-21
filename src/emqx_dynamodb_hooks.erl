-module(emqx_dynamodb_hooks).

% %% See 'Application Message' in MQTT Version 5.0
% -record(message, {
%     %% Global unique message ID
%     id :: binary(),
%     %% Message QoS
%     qos = 0,
%     %% Message from
%     from :: atom() | binary(),
%     %% Message flags
%     flags = #{} :: emqx_types:flags(),
%     %% Message headers. May contain any metadata. e.g. the
%     %% protocol version number, username, peerhost or
%     %% the PUBLISH properties (MQTT 5.0).
%     headers = #{} :: emqx_types:headers(),
%     %% Topic that the message is published to
%     topic :: emqx_types:topic(),
%     %% Message Payload
%     payload :: emqx_types:payload(),
%     %% Timestamp (Unit: millisecond)
%     timestamp :: integer()
%     }).

-include_lib("emqx/include/emqx.hrl").

-export([load/1, unload/0]).
-export([on_message_publish/2]).

load(Env) ->
    emqx:hook('message.publish', {?MODULE, on_message_publish, [Env]}).


%% Transform message and return
on_message_publish(Message = #message{topic = <<"$SYS/", _/binary>>}, _Env) ->
    {ok, Message};
on_message_publish(Message = #message{payload = Payload}, _Env) ->
    TableName = application:get_env(emqx_dynamodb, table_name, <<"">>),
    io:format("Publish ~s~n", [format(Message)]),
    PayloadPropList = decode(Payload),
    io:fwrite(PayloadPropList),
    % io:fwrite(element(1,PayloadPropList)),
    erlcloud_ddb2:put_item(TableName, PayloadPropList),
    {ok, Message}.

decode(Payload) ->
    try 
        Decoded = jiffy:decode(Payload, {return_maps}),
        io:fwrite(Decoded),
        io:fwrite("\n"),
        Decoded
    of
        Json -> Json
    catch
        error:Error -> {error,caught, Error}
    end.

format(#message{id = Id, qos = QoS, topic = Topic, from = From, payload = Payload}) ->
    io_lib:format("Message(Id=~s, QoS=~w, Topic=~s, From=~p, Payload=~s)",
                  [Id, QoS, Topic, From, Payload]).

%% Called when the plugin application stop
unload() ->
    emqx:unhook('message.publish', {?MODULE, on_message_publish}).


