# frozen_string_literal: true

# Cookbook:: iface
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

iface_device 'eth0' do
  ipv4_primary '10.0.2.15'
  ipv6_primary '2001:abcd::2/48'
  ipv4_ranges [
    %w[192.168.10.3 192.168.10.30]
  ]
  ipv6_addresses %w[
    2001:abcd::2/48
    2001:abcd::3/48
    2001:abcd::4/48
    2001:abcd::5/48
    2001:abcd::6/48
  ]
end
