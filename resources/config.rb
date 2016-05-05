#
# Cookbook Name:: zookeeper
# Resource:: config
#
# Copyright 2014, Simple Finance Technology Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include Zk::Config

default_action :render

property :conf_dir,  String, name_attribute: true
property :conf_file, String,                      required: true
property :config,    Hash,                        required: true
property :log_dir,           default: '/var/log/zookeeper'
property :env_vars,          default: {}
property :user,              default: 'zookeeper'

action :render do
  file "#{conf_dir}/#{conf_file}" do
    owner   user
    group   user
    content zookeeper_config_resource(config)
  end

  # Ensure that, even if an attribute is passed in, we can
  # operate on it without running into read-only issues
  env_vars_hash = env_vars.to_hash
  env_vars_hash['ZOOCFGDIR']   = conf_dir
  env_vars_hash['ZOOCFG']      = conf_file
  env_vars_hash['ZOO_LOG_DIR'] = log_dir

  file "#{conf_dir}/zookeeper-env.sh" do
    owner   user
    content exports_config(env_vars_hash)
  end
end

action :delete do
  Chef::Log.info "Deleting Zookeeper config at #{path}"

  [
    conf_file,
    'zookeeper-env.sh'
  ].each do |f|
    file "#{conf_dir}/#{f}" do
      action :delete
    end
  end
end
