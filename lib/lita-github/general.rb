# -*- coding: UTF-8 -*-
#
# Copyright 2014 PagerDuty, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'lita-github/r'

module LitaGithub
  # Github handler common-use methods
  #
  # @author Tim Heckman <tim@pagerduty.com>
  module General
    # Convert the value of parameter 1 to an Integer if it looks like it should be one
    #
    # @author Tim Heckman <tim@pagerduty.com>
    # @param value [String] the value to see if it should be an Integer
    # @return [Integer] if the String <tt>value</tt> looks like an Integer (<tt>/^\d+$/</tt>), return it as one
    # @return [String] if the String <tt>value</tt> is not an Integer, return as is
    def to_i_if_numeric(value)
      /^\d+$/.match(value) ? value.to_i : value
    end

    # For use when parsing options using <tt>opt_parse()</tt>, this method converts the key to a downcased symbol
    # for use within the option Hash.
    #
    # @author Tim Heckman <tim@pagerduty.com>
    # @param k [String] the key
    # @param v [Any] the value
    # @return [Array] the first element is <tt>key</tt> as a downcased symbol, the second is <tt>v</tt> with no changes
    def symbolize_opt_key(k, v)
      [k.downcase.to_sym, v]
    end

    # Parse the options in the command using the option regex
    #
    # @author Tim Heckman <tim@pagerduty.com>
    # @param cmd [String] the full command line provided to Lita
    # @return [Hash] the key:value pairs that were in the command string
    def opts_parse(cmd)
      o = {}
      cmd.scan(LitaGithub::R::OPT_REGEX).flatten.each do |opt|
        k, v = symbolize_opt_key(*opt.strip.split(':'))
        next if o.key?(k)

        # if it looks like we're using the extended option (first character is a " or '):
        #   slice off the first and last character of the string
        # otherwise:
        #   do nothing
        v = v.slice!(1, (v.length - 2)) if %w(' ").include?(v.slice(0))

        o[k] = to_i_if_numeric(v)
      end
      o
    end
  end
end
