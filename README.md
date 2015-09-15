# fluent-plugin-munin-node

Fluentd input plugin for Munin node.

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-munin-node.svg)](http://badge.fury.io/rb/fluent-plugin-munin-node)
[![Build Status](https://travis-ci.org/winebarrel/fluent-plugin-munin-node.svg)](https://travis-ci.org/winebarrel/fluent-plugin-munin-node)

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
  #tag_prefix munin
  #bulk_suffix metrics
  #service_key service
  #field_key field
  #value_key value
  #extra {}
  #bulk false
  #include_service (cpu|entropy) # regular expression
  #exclude_service df.*          # regular expression
</source>
```

## Usage

### Get munin data as multiple records

```apache
<source>
  type munin_node
  extra {"hostname", "my-host"}
</source>
```

```
2015-91-02 12:30:09 +0000 munin.cpu.user: {"service":"cpu","field":"user","value":"4192","hostname":"my-host"}
2015-91-02 12:30:09 +0000 munin.cpu.nice: {"service":"cpu","field":"nice","value":"0","hostname":"my-host"}
2015-91-02 12:30:09 +0000 munin.cpu.system: {"service":"cpu","field":"system","value":"1935","hostname":"my-host"}
```

## Get munin data as a single record

```apache
<source>
  type munin_node
  extra {"hostname", "my-host"}
  bulk true
</source>
```

```
2015-01-02 12:30:40 +0000 munin.metrics: {"cpu":{"user":"4112","nice":"0","system":"1894",...,"hostname":"my-host"}
```
