# Yahoo Ads input plugin for Embulk
Embulk input plugin for Yahoo Promotion Ads.

## Overview
* **Plugin type**: input
* **Resume supported**: no
* **Cleanup supported**: no
* **Guess supported**: no

## Configuration
- **location**: 利用するAPIのlocation。検索広告とディスプレイ広告で異なる. (string, required)
- **version**: 利用するAPIのlocation。検索広告とディスプレイ広告で異なる. (string, required)
- **license**: Yahoo社から提供される認証情報 (string, required)
- **api_account**: Yahoo社から提供される認証情報 (string, required)
- **api_password**: API認証のためのパスワード (string, required)
- **namespace**: 利用するAPIのlocation。検索広告とディスプレイ広告で異なる. (string, required)
- **report_type**: レポートタイプ (string, required)
- **account_id**: 取得するアカウントのID (string, required)
- **date_range_min**: 取得するレポート期間の開始日. フォーマットは"YYYYMMDD" (string, required)
- **date_range_max**: 取得するレポート期間の終了日. フォーマットは"YYYYMMDD" (string, required)
- **columns**: 取得するレポートの列 (array, required)

## Example
```yaml
in:
  type: yahoo_ads
  location: xxxxx.yahooapis.jp
  version: Vx.x
  license: xxxx-xxxx-xxxx-xxxx
  api_account: yyyy-yyyy-yyyy-yyyy
  api_password: xyz
  namespace: http://abc.yahooapis.jp/V0
  report_type: CAMPAIGN
  account_id: 000000000
  date_range_min: 20171201
  date_range_max: 20171210
  columns:
    - CAMPAIGN_NAME
    - DAY
    - IMPS
    - CLICK
    - COST
    - CONVERSIONS
```


## Build
```
$ rake
```
