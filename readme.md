# Diginet

While Digilines is a great low-level protocol allowing for simple
communication between nodes, sometimes a little more structure is helpful.

If you think of Digilines as roughly between the level of Ethernet and
TCP, Diginet is an application-level protocol more like HTTP, though
it has to introduce a notion of addressing too.

## Addressing

[Positions](http://dev.minetest.net/position) function as addresses
for nodes; as such they contain X, Y, and Z coordinates. You can also
pass position strings (as per `minetest.pos_to_string`) and they will
be normalized to position tables before the packets are delivered.

In the future addresses may also include wildcards or ranges in order
to function as broadcast or multicast.

* `(12,85,-12)` - addresses a single node
* `(*,*,*)` - addresses all nodes in a network
* `(*,0-255,*)` - addresses all nodes from Y=0 to Y=255

## Packets

Each packet is a lua table with three required fields:

* `source`: an address
* `destination`: an address
* `method`: what action this packet is intended to achieve

Optional fields include:

* `player`: the player who initiated the packet, if applicable
* `request_id`: if you expect a response, include a UUID (etc) in this field
* `in_reply_to`: when replying to a packet with a request id, place the id in this field of the response

Though of course you can include whatever fields you like.

## Ping

TODO: All Diginet-aware nodes should reply to ping packets:

    {source="(12,-5,23)", destination="(*,*,*)", method="ping"}

Responses should include `method="pong"` as well as a list of all
methods which the given node will respond.

    {source="(19,0,-10)", destination="(12,-5,23)", method="pong",
     methods={"ping", "open", "close", "toggle"}}

Replying to pings will be handled by the diginet library as long as
you define all your packet handlers declaratively so that diginet can
calculate the methods with which to respond.

## Error handlers

Needs a callback for what happens if the source does not exist.

TODO: describe in more detail

## API

Send diginet messages using `diginet.send`:

    diginet.send({ source="12,700,1", destination="19,21,86",
                   method="post", body="hi"})

Set up your handlers to receive messages by including a `diginet`
field in your call to `minetest.register_node`:

    minetest.register_node("hello:world", { description = "hello block",
                                            ...
                                            diginet = {
                                              post = mymod.on_post,
                                              open = mymod.on_open,
                                            }}

All handler functions will receive a `pos` argument for the node in
question as well as a `packet` argument with the packet table.

There is also a `diginet.reply` function which is simply a convenience
wrapper around `diginet.send` which takes an original packet and a
response packet, and sets the `source`, `destination`, `player`, and
`in_reply_to` fields on the response, and sends it.

## License

Copyright © 2015 Phil Hagelberg and contributors.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License (in the file COPYING) for more details.
