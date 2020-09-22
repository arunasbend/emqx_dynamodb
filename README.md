# Prerequisites
Erlang runtime
rebar3

# Guidelines
Each plugin should have a 'etc/{plugin_name}.conf|config' file to store application config.

# Deploy
1. Clone deploy tool
> git clone https://github.com/emqx/emqx-rel.git emqx-rel
> cd emqx-rel
2. Add dependency in rebar.config
```
{deps,
  [ 
    {plugin_name, {git, "url_of_plugin", {tag, "tag_of_plugin"}}},
    {emqx_dynamodb, {git, "https://github.com/arunasbend/emqx_dynamodb", {branch,"master"}}}
  ]
}
```
3. Load package in rebar.config (and add dependencies, or they won't be started)
{relx,
    [...
    , ...
    , {release, {emqx, git_describe},
       [
          {hackney, load},
          {erlcloud, load},
          {emqx_dynamodb, load}
       ]
      }
    ]
}
4. Make a package
> make emqx-pkg
> ls _packages/emqx

###
(sudo apt install erlang-cuttlefish)