# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition.


# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  path => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# DEFAULT NODE
# Node definitions in this file are merged with node data from Foreman.

# The default node definition matches any node lacking a more specific node
# definition. Since there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in Foreman for that node.
node default {
  # Only the base profile is included here.
  # All other classes should come from the Foreman ENC
  include ::elevenware_base
}
