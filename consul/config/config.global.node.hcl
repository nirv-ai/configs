# node_id = set via cli: -node-id $UNIQUE-UUID
# node_name = set via cli: -node $UNIQUE-HOSTNAME

disable_host_node_id = false # enable nomad + consul to use same algo

node_meta {
  ENV = "development"
}
