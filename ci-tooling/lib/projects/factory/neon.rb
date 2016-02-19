# frozen_string_literal: true
#
# Copyright (C) 2016 Harald Sitter <sitter@kde.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.

require_relative 'base'

class ProjectsFactory
  # Neon specific project factory.
  class Neon < Base
    DEFAULT_URL_BASE = 'git://packaging.neon.kde.org.uk'.freeze

    # FIXME: needs a writer!
    def self.url_base
      @url_base ||= DEFAULT_URL_BASE
    end

    def self.understand?(type)
      type == 'packaging.neon.kde.org.uk'
    end

    private

    def split_entry(entry)
      parts = entry.split('/')
      name = parts[-1]
      component = parts[0..-2].join('_') || 'neon'
      [name, component]
    end

    def params(str)
      # FIXME: branch hardcoded!!@#!$%!!
      # FIXME: also in debian
      # FIXME: also in github
      name, component = split_entry(str)
      default_params.merge(
        name: name,
        component: component,
        url_base: self.class.url_base
      )
    end

    def from_string(str, params = {})
      kwords = params(str)
      kwords.merge!(symbolize(params))
      puts "new_project(#{kwords})"
      new_project(**kwords)
    rescue Project::GitTransactionError, RuntimeError => e
      # FIXME: eating exception
      # Runtime raised by bad control files
      # Transaction raised by bad transactions
      p e
      nil
    end

    def split_hash(hash)
      clean_hash(*hash.first)
    end

    def clean_hash(base, subset)
      subset.collect! do |sub|
        # Coerce flat strings into hash. This makes handling more consistent
        # further down the line. Flat strings simply have empty properties {}.
        sub = sub.is_a?(Hash) ? sub : { sub => {} }
        # Convert the subset into a pattern matching set by converting the
        # keys into suitable patterns.
        key = sub.keys[0]
        sub[CI::FNMatchPattern.new("#{base}/#{key}")] = sub.delete(key)
        sub
      end
      [base, subset]
    end

    def each_pattern_value(subset)
      subset.each do |sub|
        pattern = sub.keys[0]
        value = sub.values[0]
        yield pattern, value
      end
    end

    def match_path_to_subsets(path, subset)
      matches = {}
      each_pattern_value(subset) do |pattern, value|
        next unless pattern.match?(path)
        match = [path, value] # This will be an argument list for from_string.
        matches[pattern] = match
      end
      matches
    end

    def from_hash(hash)
      base, subset = split_hash(hash)
      raise 'not array' unless subset.is_a?(Array)

      selection = self.class.ls.collect do |path|
        next nil unless path.start_with?(base) # speed-up, these can't match...
        matches = match_path_to_subsets(path, subset)
        # Get best matching pattern.
        CI::PatternBase.sort_hash(matches).values[0]
      end
      selection.compact.collect { |s| from_string(*s) }
    end

    class << self
      def ls
        return @listing if defined?(@listing) # Cache in class scope.
        listing = `ssh gitolite3@packaging.neon.kde.org.uk`.chop.split($/)
        # FIXME: proper error
        raise unless $? == 0
        listing.shift # welcome message leading, drop it.
        @listing = listing.collect do |entry|
          entry.split(' ')[-1]
        end.uniq.compact.freeze
      end
    end
  end
end
