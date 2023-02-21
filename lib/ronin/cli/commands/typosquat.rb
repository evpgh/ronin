# frozen_string_literal: true
#
# Copyright (c) 2006-2023 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# Ronin is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ronin is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ronin.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/cli/value_processor_command'
require 'ronin/cli/typo_options'

require 'ronin/support/network/domain'

module Ronin
  class CLI
    module Commands
      #
      # Finds typo squatted domains.
      #
      # ## Usage
      #
      #     ronin typosquat [options] DOMAIN
      #
      # ## Options
      #
      #         --omit-chars                 Toggles whether to omit repeated characters
      #         --repeat-chars               Toggles whether to repeat single characters
      #         --swap-chars                 Toggles whether to swap certain common character pairs
      #         --change-suffix              Toggles whether to change the suffix of words
      #         -A, --has-addresses          Print typo squat domains with addresses
      #         -r, --registered             Print typo squat domains that are already registered
      #         -u, --unregistered           Print typo squat domains that can be registered
      #     -h, --help                       Print help information
      #
      # ## Arguments
      #
      #     DOMAIN                           The domain to typo squat
      #
      class Typosquat < ValueProcessorCommand

        include TypoOptions

        option :has_addresses, desc: 'Print typo squat domains with addresses'

        option :registered, desc: 'Print typo squat domains that are already registered'

        option :unregistered, desc: 'Print typo squat domains that can be registered'

        argument :domain, required: true,
                          desc:     'The domain to typo squat'

        description 'Finds typo squatted domains'

        man_page 'ronin-typosquat.1'

        #
        # Processes each word.
        #
        # @param [String] domain
        #   A word argument to typo.
        #
        def run(domain)
          if options[:has_addresses]
            each_typo_squat(domain) do |typo_domain|
              puts typo_domain if typo_domain.has_addresses?
            end
          elsif options[:registered]
            each_typo_squat(domain) do |typo_domain|
              puts typo_domain if typo_domain.registered?
            end
          elsif options[:unregistered]
            each_typo_squat(domain) do |typo_domain|
              puts typo_domain if typo_domain.unregistered?
            end
          else
            each_typo_squat(domain) do |typo_domain|
              puts typo_domain
            end
          end
        end

        #
        # Enumerates over each typosquat of the domain.
        #
        # @param [String] domain
        #   The domain to typo squat.
        #
        # @yield [typo_domain]
        #   The given block will be passed each new typo squated domain.
        #
        # @yieldparam [Ronin::Support::Network::Domain] typo_domain
        #   A typo squated variation on the input domain.
        #
        def each_typo_squat(domain)
          domain = Support::Network::Domain.new(domain)
          suffix = domain.suffix
          name   = domain.name.chomp(suffix)

          typo_generator.each_substitution(name) do |typo|
            yield Support::Network::Domain.new("#{typo}#{suffix}")
          end
        end

      end
    end
  end
end
