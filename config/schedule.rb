# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "./log/cron_log.log"
#

every 10.minutes do
  runner "Shnwp::Gfs.new.fetch_latest"
end

every 10.minutes do
  runner "Shnwp::Hycom.new.fetch_latest"
end

every 10.minutes do
  runner "Shnwp::Nww3.new.fetch_latest"
end

every 10.minutes do
  runner "Shnwp::Warms.new.fetch_latest"
end

# Learn more: http://github.com/javan/whenever
every 1.day, :at => '20:25' do
  runner "Shnwp::Fc.new.fetch_latest"
end

every 1.day, :at => '20:25' do
  runner "Shnwp::Cw.new.fetch_latest"
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
