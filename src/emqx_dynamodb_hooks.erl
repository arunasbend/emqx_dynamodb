-module(emqx_dynamodb_hooks).

-include_lib("emqx/include/emqx.hrl").

-export([load/1, unload/0]).

%% Message Pubsub Hooks
-export([on_message_publish/2]).

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

%% Called when the plugin application start
load(Env) ->
    emqx:hook('message.publish', {?MODULE, on_message_publish, [Env]}).

%%--------------------------------------------------------------------
%% Message PubSub Hooks
%%--------------------------------------------------------------------

%% Transform message and return
on_message_publish(Message = #message{topic = <<"$SYS/", _/binary>>}, _Env) ->
    {ok, Message};
on_message_publish(Message = #message{payload = Payload}, _Env) ->
    TableName = application:get_env(emqx_dynamodb, table_name, <<"">>),
    erlcloud:put_item(TableName, Payload),
    io:format("Publish ~s~n", [format(Message)]),
    {ok, Message}.

format(#message{id = Id, qos = QoS, topic = Topic, from = From, payload = Payload}) ->
    io_lib:format("Message(Id=~s, QoS=~w, Topic=~s, From=~p, Payload=~s)",
                  [Id, QoS, Topic, From, Payload]).

%% Called when the plugin application stop
unload() ->
    emqx:unhook('message.publish', {?MODULE, on_message_publish}).
