# fluent-plugin-munin-node

Fluentd input plugin for Munin node.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-munin-node'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-munin-node

## Configuration

```apache
<source>
  type munin_node

  #node_host 127.0.0.1
  #node_port 10050
  #interval 60
  #tag munin.item
  #plugin_key plugin
  #datasource_key datasource
  #item_value_key value
  #extra {}
  #bulk false
</source>
```

## Usage

### Get munin datasources as multiple records

```apache
<source>
  type munin_node
  extra {"hostname", "my-host"}
</source>
```

```
2015-91-02 12:30:09 +0000 munin.item: {"plugin":"cpu","datasource":"user","value":"4192","hostname":"my-host"}
2015-91-02 12:30:09 +0000 munin.item: {"plugin":"cpu","datasource":"nice","value":"0","hostname":"my-host"}
2015-91-02 12:30:09 +0000 munin.item: {"plugin":"cpu","datasource":"system","value":"1935","hostname":"my-host"}
```

## Get munin datasources as a single record

```apache
<source>
  type munin_node
  extra {"hostname", "my-host"}
  bulk true
</source>
```

```
2015-01-02 12:30:40 +0000 munin.item: {"cpu":{"user":"4112","nice":"0","system":"1894",...,"hostname":"my-host"}
```
