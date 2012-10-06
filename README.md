toptweet-crawler
================

Twitterで人気を集めたツイートを様々なソースから収集します。
現在はfavstar, favotterに対応しています。

status_idは上記のサイトをクロールして入手し、
ツイート本体はTwitter APIで取得します。

config.yaml
-----------
カレントディレクトリにconfig.yamlを置いてください。

Twitterの認証情報

    consumer_key: (snip)
    consumer_secret: (snip)
    oauth_token: (snip)
    oauth_token_secret: (snip)
