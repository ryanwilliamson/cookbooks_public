#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

#Installing some apache development headers required for rubyEE
node[:app_passenger][:ruby_packages_install].each do |p|
  package p
end

#Installing some apache development headers required for passenger compilation
node[:app_passenger][:packages_install].each do |p|
  package p
end

#Databag for inputs from web_apache recipe, to run "do_update_code" in operational state
app_data = Chef::DataBag.new
app_data.name("app_data")
app_data.save

app_name = {
  "application_name" => "#{node[:web_apache][:application_name]}",
}
databag_item = Chef::DataBagItem.new
databag_item.data_bag("app_data")
databag_item.raw_data = app_name
databag_item.save



rs_utils_marker :end
