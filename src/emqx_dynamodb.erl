-module(emqx_dynamodb).

-behaviour(application).

-emqx_plugin(?MODULE).

-export([ start/2
        , stop/1
        ]).

start(_StartType, _StartArgs) ->
    application:set_env(erlcloud, aws_access_key_id, application:get_env(emqx_dynamodb, aws_access_key_id, "")),
    application:set_env(erlcloud, aws_secret_access_key, application:get_env(emqx_dynamodb, aws_secret_access_key, "")),
    application:set_env(erlcloud, aws_region, application:get_env(emqx_dynamodb, aws_region, "")),

    application:ensure_all_started(hackney),
    application:ensure_all_started(erlcloud),
    {ok, Sup} = emqx_dynamodb_sup:start_link(),
    emqx_dynamodb_hooks:load(application:get_all_env()),
    {ok, Sup}.

stop(_State) ->
    emqx_dynamodb_hooks:unload().

