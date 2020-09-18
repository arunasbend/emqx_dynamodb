-module(emqx_dynamodb_app).

-behaviour(application).

-emqx_plugin(?MODULE).

-export([ start/2
        , stop/1
        ]).

start(_StartType, _StartArgs) ->
    {ok, Sup} = emqx_dynamodb_sup:start_link(),
    emqx_dynamodb:load(application:get_all_env()),
    {ok, Sup}.

stop(_State) ->
    emqx_dynamodb:unload().
