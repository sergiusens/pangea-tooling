require_relative 'lib/testcase'

require_relative '../lib/dci'

class DCITest < TestCase
  def assert_equal_collection(expected, actual)
    assert_equal(expected.sort, actual.sort)
  end

  def test_types
    assert_equal_collection(%w(desktop), DCI.types)
  end

  def test_architectures
    assert_equal_collection(%w(amd64), DCI.architectures)
  end

  def test_extra_architectures
    assert_equal_collection(%w(), DCI.extra_architectures)
  end

  def test_all_architectures
    assert_equal_collection(%w(amd64), DCI.all_architectures)
  end

  def test_series
    assert_equal_collection(%w(1901 stretch next), DCI.series.keys)
    assert_equal_collection(%w(20181001 20170617 20190606), DCI.series.values)
    assert_equal('20181001', DCI.series['1901'])
    assert_equal('20170617', DCI.series['stretch'])
    assert_equal('20190606', DCI.series['next'])

    # With sorting
    assert_equal('stretch', DCI.series(sort: :ascending).keys.first)
  end

  def test_latest_series
    assert_equal('next', DCI.latest_series)
  end
end
