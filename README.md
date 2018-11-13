# Liquor

A clumsy filtering library, loosely based on lucene.

This library is still a work in progress and may be buggy as a old house infested with termites.

## Usage

First you must define a search spec, luckily it's just a plain old map

```
my_search_spec = %{
  # Whitelists can be a map containing the name of each 'allowed' field.
  whitelist: %{
    "_" => true, # "_" is a special key for strings with no key
    "derp" => nil, # this field will be rejected
    "body" => true, # this field will be allowed,
    "kind" => :message_kind, # the field will be renamed to `message_kind` and accepted
    "date" => :date,
  },
  # transforms tell liquor how to convert the whitelisted fields
  transform: %{
    _: {:type, :string}, # a special handler for keywords
    body: {:type, :string}, # uses Ecto.Type.cast(:string)
    message_kind: {:mod, MessageKindEnum}, # works with Ecto.Type modules
    date: {:type, :date}, # dates, datetimes and time have special transforms
  },
  # filter tells liquor how to handle the transformed values when adding it to the query
  filter: %{
    _: {:apply, MyFilter, :filter_keyword, []}, # an apply can be used, here it's being used for the keywords
    body: {:type, :string}, # treats the value as a string, this gives access to wildcards
    message_kind: {:type, :atom}, #
    date: {:type, :date}, # date, datetime and time are subject to special handling
  },
}

messages =
  Message
  |> Liquor.apply_search("date:year:2018 body:'Hello '*", my_search_spec)
  |> Repo.all()
```

## TODO

Introduce a DSL, or at least some helper functions for building the `search_spec`
