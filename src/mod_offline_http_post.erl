%% mod_offline_http_post.erl
%% Update: ibrahimkoujar91@gmail.com
-module(mod_offline_http_post).
-author("IbrahimKoujar").

%% Every ejabberd module implements the gen_mod behavior
%% The gen_mod behavior requires two functions: start/2 and stop/1
-behaviour(gen_mod).

-export([start/2, stop/1, create_message/1, create_message/3]).
-export([mod_opt_type/1, mod_options/1, depends/2]).

%% Required by ?INFO_MSG macros
-include("logger.hrl").
-include("scram.hrl").
-include("xmpp.hrl").

start(_Host, _Opt) ->
  ?INFO_MSG("mod_offline_http_post loading", []),
  inets:start(),
  ?INFO_MSG("HTTP client started", []),
  ejabberd_hooks:add(offline_message_hook, _Host, ?MODULE, create_message, 1).

stop (_Host) ->
  ?INFO_MSG("stopping mod_offline_http_post", []),
  ejabberd_hooks:delete(offline_message_hook, _Host, ?MODULE, create_message, 1).

create_message({Packet} = Acc) when (Packet#message.type == chat) and (Packet#message.body /= []) ->
	[{text, _, Body}] = Packet#message.body,
	post_offline_message(Packet#message.from, Packet#message.to, Body, Packet#message.id),
  Acc;

create_message(Acc) ->
  Acc.

create_message(_From, _To, Packet) when (Packet#message.type == chat) and (Packet#message.body /= []) ->
  Body = fxml:get_path_s(Packet, [{elem, list_to_binary("body")}, cdata]),
  MessageId = fxml:get_tag_attr_s(list_to_binary("id"), Packet),
  post_offline_message(_From, _To, Body, MessageId),
  ok.

post_offline_message(From, To, Body, MessageId) ->

  ?INFO_MSG("Posting From ~p To ~p Body ~p ID ~p~n",[From, To, Body, MessageId]),
  
  Token = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, token),
  PostUrl = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, post_url),
  Confidential = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, confidential),

  ToUser = To#jid.luser,
  FromUser = From#jid.luser,
  Vhost = To#jid.lserver,

  case Confidential of
    true -> Data = string:join(["to=", binary_to_list(ToUser), "&from=", binary_to_list(FromUser), "&vhost=", binary_to_list(Vhost), "&messageId=", binary_to_list(MessageId)], "");
    false -> Data = string:join(["to=", binary_to_list(ToUser), "&from=", binary_to_list(FromUser), "&vhost=", binary_to_list(Vhost), "&body=", binary_to_list(Body), "&messageId=", binary_to_list(MessageId)], "")
  end,

  Request = {PostUrl, [{"Authorization", Token}], "application/x-www-form-urlencoded", Data},
  httpc:request(post, Request,[],[]),

  ?INFO_MSG("post request sent", []).

depends(_Host, _Opts) ->
  [].

mod_opt_type(token) ->
  econf:string();
mod_opt_type(post_url) ->
  econf:string();  
mod_opt_type(confidential) ->
  econf:bool().

mod_options(_Host) ->
  [
    {token, "secret"},
    {post_url, "http://localhost/api"},
    {confidential, false}
  ].

