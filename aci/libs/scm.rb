#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright (C) 2016 Scarlett Clark <sgclark@kde.org>
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
require 'rugged'

# Module for source control
class SCM
  attr_accessor :url
  attr_accessor :branch
  attr_accessor :dir
  attr_accessor :type
  def initialize(args = {})
    @url = args[:url]
    @branch = args[:branch]
    @dir = args[:dir]
    @type = args[:type]
  end

  # Case block to select appriate scm type.
  def select_type
    case type
    when 'git'
      SCM.git_clone_source(url, dir, branch)
    end
  end

  # Clone a git repo
  def self.git_clone_source(url, dir, branch)
    Rugged::Repository.clone_at(
      url,
      dir,
      checkout_branch: branch,
      transfer_progress: lambda { |total_objects, indexed_objects, received_objects, local_objects, total_deltas, indexed_deltas, received_bytes|
        # ...
      }
    )
  end
end
