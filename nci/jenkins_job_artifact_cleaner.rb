#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Copyright (C) 2017 Harald Sitter <sitter@kde.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) version 3, or any
# later version accepted by the membership of KDE e.V. (or its
# successor approved by the membership of KDE e.V.), which shall
# act as a proxy defined in Section 6 of version 3 of the license.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.

require 'fileutils'

require_relative '../ci-tooling/lib/ci/pattern'

module NCI
  # Cleans up artifacts of lastSuccessfulBuild of jobs passed as array of
  # names.
  module JenkinsJobArtifactCleaner
    # Logic wrapper encapsulating the cleanup logic of a job.
    class Job
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def jobs_dir
        @jobs_dir ||= File.join(ENV.fetch('JENKINS_HOME'), 'jobs')
      end

      def path
        File.join(jobs_dir, name, 'builds/lastSuccessfulBuild/archive')
      end

      def clean!
        puts "Cleaning #{name} in #{path}"
        Dir.glob("#{path}/**/**") do |entry|
          next if File.directory?(entry)
          next unless BLACKLIST.any? { |x| x.match?(entry) }
          FileUtils.rm(entry, verbose: true)
        end
      end
    end

    BLACKLIST = [
      CI::FNMatchPattern.new('*.deb'),
      CI::FNMatchPattern.new('*.udeb'),
      CI::FNMatchPattern.new('*.orig.tar.*')
    ].freeze

    module_function

    def run(jobs)
      warn 'Cleaning up job artifacts to conserve disk space.'
      jobs.each do |job|
        Job.new(job).clean!
      end
    end
  end
end

NCI::JenkinsJobArtifactCleaner.run(ARGV) if $PROGRAM_NAME == __FILE__
