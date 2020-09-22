-module(emqx_dynamodb_hooks).

-include_lib("emqx/include/emqx.hrl").
-include_lib("erlcloud/include/erlcloud_aws.hrl").

-export([load/1, unload/0]).
-export([on_message_publish/2]).

load(Env) -> emqx:hook('message.publish', {?MODULE, on_message_publish, [Env]}).
unload() -> emqx:unhook('message.publish', {?MODULE, on_message_publish}).

%% Transform message and return
on_message_publish(Message = #message{topic = <<"$SYS/", _/binary>>}, _Env) ->
    {ok, Message};
on_message_publish(Message = #message{payload = Payload}, _Env) ->
    TableName = application:get_env(emqx_dynamodb, table_name, <<"">>),
    AccessId = application:get_env(emqx_dynamodb, aws_access_key_id, ""),
    AccessSecret = application:get_env(emqx_dynamodb, aws_secret_access_key, ""),
    Region = application:get_env(emqx_dynamodb, aws_region, ""),
    
    {Decoded} = jiffy:decode(Payload),
    Props = parse(Decoded),

    Config = erlcloud_aws:default_config(),
    ConfigWithSecrets = Config#aws_config{
        access_key_id=AccessId,
        secret_access_key=AccessSecret,
        aws_region=Region,
        retry_num=1,
        http_client=hackney,
        ddb_scheme="https://",
        ddb_port=80,
        ddb_host="dynamodb.eu-central-1.amazonaws.com"
    },
    erlcloud_ddb2:put_item(list_to_binary(TableName), Props, [], ConfigWithSecrets),
    {ok, Message}.

parse(Json) ->
    Keys = proplists:get_keys(Json),
    parse(Json, Keys, []).
parse(Json, [Key|Keys], Props) ->
    Value = proplists:get_value(Key, Json),
    parse(Json, Keys, [{Key, Value} | Props]);
parse(_, [], Props) ->
    Props.
