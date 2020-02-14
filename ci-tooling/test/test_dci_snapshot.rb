#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Copyright (C) 2016 Harald Sitter <sitter@kde.org>
# Copyright (C) 2016 Bhushan Shah <bshah@kde.org>
# Copyright (C) 2016 Rohan Garg <rohan@kde.org>
# Copyright (C) 2019 Scarlett Moore <sgmoore@kde.org>
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

require_relative '../dci/snapshot'
require_relative 'lib/testcase'

require 'mocha/test_unit'
require 'webmock/test_unit'

class DCISnapshotTest < TestCase
  def setup
    # Disable all web (used for key).
    WebMock.disable_net_connect!
    ENV['FLAVOR'] = 'netrunner-desktop'
    ENV['VERSION'] = 'next'
    @d = DCISnapshot.new
  end

  def teardown
    WebMock.allow_net_connect!
    ENV['FLAVOR'] = ''
    ENV['VERSION'] = ''
  end

  def test_config
    setup
    data = @d.config
    assert_is_a(data, Hash)
    teardown
  end

  def test_components
    setup
    data = @d.components
    assert_is_a(data, Array)
    test_data = %w[netrunner extras backports ds9-artwork ds9-common netrunner-desktop]
    assert_equal test_data, data
    teardown
  end

  def test_repo_array
    setup
    data = @d.repo_array
    assert data.include?('netrunner-desktop-next')
    teardown
  end

  def test_arch_array
    setup
    data = @d.arch_array
    assert data.include?('amd64')
    teardown
  end

  def test_versioned_dist
    setup
    v_dist = @d.versioned_dist
    assert_equal('netrunner-desktop-next', v_dist)
    teardown
  end

  def test_aptly_options
    setup
    data = @d.aptly_options
    opts = {}
    opts[:Distribution] = 'netrunner-desktop-next'
    opts[:Architectures] = %w[amd64 i386 all source]
    opts[:ForceOverwrite] = true
    opts[:SourceKind] = 'snapshot'
    assert_equal(opts, data)
    teardown
  end
end
