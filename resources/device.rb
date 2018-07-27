# frozen_string_literal: true

#
# resource: device
#

require 'iface'

# TODO: remove ipv6_primary from ipv6_addresses
property :device_name, String, name_property: true
property :ipv4_primary, String
property :ipv6_primary, String
property :ipv4_ranges, Array
property :ipv6_addresses, Array

timestamp = Time.now.strftime('%Y%m%d%H%M%S')
existing_network = Iface::Config.discover('/etc/sysconfig/network-scripts/ifcfg-*')
existing_device = nil

load_current_value do
  existing_device = existing_network[name]
  ipv4_primary existing_device&.ip_address
  ipv6_primary existing_device&.ipv6_address
  ipv6_addresses existing_device&.ipv6_secondaries
  ipv4_ranges [] # TODO
end

action :manage do
  converge_if_changed :ipv4_primary, :ipv6_primary, :ipv6_addresses do
    # back up primary file
    if existing_device
      dirname, filename = ::File.split(existing_device.filename)
      backup_path = ::File.join(dirname, "#{timestamp}.#{filename}")
      file backup_path do
        content ::File.read(existing_device.filename)
        mode '0644'
        owner 'root'
        group 'root'
      end
    end

    # write new primary file
    new_device = existing_device ? existing_device.dup : Iface::PrimaryFile.new
    new_device.ip_address = new_resource.ipv4_primary if new_resource.ipv4_primary
    new_device.ipv6_address = new_resource.ipv6_primary if new_resource.ipv6_primary
    new_device.ipv6_secondaries = new_resource.ipv6_addresses if new_resource.ipv6_addresses

    file existing_device.filename do
      content new_device.to_s
      mode '0644'
      owner 'root'
      group 'root'
    end
  end

  converge_if_changed :ipv4_ranges do
    # TODO: remove existing range files

    # TODO: write new range files
  end

  # TODO: restart networking if any files were written
end
