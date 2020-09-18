-module(emqx_dynamodb).

-include_lib("emqx/include/emqx.hrl").

-export([load/1, unload/0]).

%% Message Pubsub Hooks
-export([on_message_publish/2]).

%% Called when the plugin application start
load(Env) ->
    emqx:hook('message.publish', {?MODULE, on_message_publish, [Env]}).

%%--------------------------------------------------------------------
%% Message PubSub Hooks
%%--------------------------------------------------------------------

%% Transform message and return
on_message_publish(Message = #message{topic = <<"$SYS/", _/binary>>}, _Env) ->
    {ok, Message};
on_message_publish(Message, _Env) ->
    io:format("Publish ~s~n", [emqx_message:format(Message)]),
    {ok, Message}.

%% Called when the plugin application stop
unload() ->
    emqx:unhook('message.publish', {?MODULE, on_message_publish}).
