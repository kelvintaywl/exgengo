# Gengo

Elixir client library for [Gengo API](http://developers.gengo.com)

## Supported Endpoints

- [Get Language Pairs](http://developers.gengo.com/v2/api_methods/service/#language-pairs-get)
- [Get Languages](http://developers.gengo.com/v2/api_methods/service/#languages-get)
- [Get Account Stats](http://developers.gengo.com/v2/api_methods/account/#stats-get)
- [Get Account Personal](http://developers.gengo.com/v2/api_methods/account/#me-get)
- [Get Account Balance](http://developers.gengo.com/v2/api_methods/account/#balance-get)
- [Post Jobs for translation](http://developers.gengo.com/v2/api_methods/jobs/#jobs-post)

## Usage

```elixir
public_key = "HELLO"
private_key = "HUSH"

Gengo.API.language_pairs(public_key, private_key)
# [%Gengo.API.LanguagePair{lc_src: "en", lc_tgt: "ja", tier: "standard", unit_price: 0.05, currency: "USD"}, ..]

Gengo.API.me(public_key, private_key)
# %Gengo.API.Account{display_name: "John", email: "johndoe@example.com",full_name: "John Doe", language_code: "en"}
```
