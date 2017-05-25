# Gengo

Elixir client library for [Gengo API](http://developers.gengo.com)

## Usage

Retrieve your [Gengo account's public & private keys](https://gengo.com/account/api_settings/)

Set your Gengo API public key and private key via the `GENGO_API_KEY` and `GENGO_API_SECRET` environment variable respectively.

```elixir
Gengo.me
# %{display_name: "erlich.bachman", email: "erlich@pipedpiper.co", full_name: "Erlich Bachman", language_code: "en"}
```
