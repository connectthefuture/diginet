-- DNS server

diginet.hostnames = {}

local formspec = function(entries)
   -- TODO: support arbitrary number of entries
   local fields = "field[0.5,1.5;3,1;alias1;alias;myhost]" ..
      "field[4,1.5;3,1;pos1;position;(0,3,75)]" ..
      "field[0.5,2.5;3,1;alias2;alias;]" ..
      "field[4,2.5;3,1;pos2;position;]" ..
      "field[0.5,3.5;3,1;alias3;alias;]" ..
      "field[4,3.5;3,1;pos3;position;]" ..
      "field[0.5,4.5;3,1;alias4;alias;]" ..
      "field[4,4.5;3,1;pos4;position;]"
   return "size[8,10]" ..
      fields ..
      "button[0.5,9.5;3,1;save;save]"
end

local on_construct = function(pos)
   local meta = minetest.get_meta(pos)
   meta:set_string("formspec", formspec())
end

local on_receive_fields = function(pos, _formname, fields, player)
   print("received")
   print(minetest.serialize(fields))
   local meta = minetest.get_meta(pos)
   meta:set_string("formspec", formspec())

   -- TODO: support arbitrary entries
   for k,v in pairs({alias1 = "pos1", alias2 = "pos2", alias3 = "pos3",
                     alias4 = "pos4"}) do
      if(fields[v] and not fields[v]:match("^$")) then
         print("DNS: setting " .. fields[k] .. " to " .. fields[v])
         diginet.hostnames[fields[k]] = fields[v]
      end
   end
end

local set_hostname = function(pos, packet)
   diginet.hostnames[packet.alias] = packet.position
end

local hostnames_path = minetest.get_worldpath() .. "/diginet_hostnames"

local save_hostnames = function()
   local file = io.open(hostnames_path, "w")
   file:write(minetest.serialize(diginet.hostnames))
   file:close()
end

local load_hostnames = function()
   print("Loading diginet hostnames...")
   local file = io.open(hostnames_path, "r")
   local contents = file and file:read("*all")
   if file then file:close() end
   if(file and contents ~= "") then
      for k,v in pairs(minetest.deserialize(contents)) do
         diginet.hostnames[k] = v
      end
   else
      return {}
   end
end

minetest.register_node("diginet:dns", {
                          description = "DNS Server",
                          paramtype = "light",
                          paramtype2 = "facedir",
                          walkable = true,
                          tiles = {
                             "terminal_top.png",
                             "digicode_side.png",
                             "digicode_side.png",
                             "digicode_side.png",
                             "digicode_side.png",
                             "terminal_front.png"
                          },
                          diginet = { set_hostname = set_hostname,},
                          groups = { dig_immediate = 2 },
                          on_construct = on_construct,
                          on_receive_fields = on_receive_fields,
})

minetest.register_on_shutdown(save_hostnames)
load_hostnames()
