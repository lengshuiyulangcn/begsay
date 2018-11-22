require "httparty"
require "csv"
require "json"
require "pp"
require 'terminal-table'
require 'money'
require 'rainbow/refinement'
require './notification.rb'

using Rainbow

Money.use_i18n = false

LOGFILE = __dir__ + "/log"

# PUSHOVER_USER_KEY=ENV["PUSHOVER_USER_KEY"]
# PUSHOVER_APPLICATION_KEY=ENV["PUSHOVER_APPLICATION_KEY"]
# @messanger = PushOver::Message.new(PUSHOVER_USER_KEY, PUSHOVER_APPLICATION_KEY)

def get_assets
  position = {}
  data = []
  CSV.foreach( __dir__ + "/config.csv") do |row|
    # BTC,1
    # ETH,40
    currency = row[0]
    position[currency] = row[1]
    respose = HTTParty.get("https://api.coinmarketcap.com/v1/ticker/#{currency}/?convert=jpy")
    data += JSON.parse(respose.body)
  end
  pairs = data.select do |currency|
    !!position[currency["id"]] == true
  end
  total = 0
  logfile = File.open(LOGFILE, 'a+')
  last_total = logfile.to_a.last.strip.to_i
  listup = []
  pairs.each do |currency|
    mark = currency["name"]
    amount = position[currency["id"]]
    price = currency["price_jpy"].to_f.round(3).to_s
    change_in_24 = "#{currency["percent_change_24h"]}%"
    sum = (position[currency["id"]].to_f * currency["price_jpy"].to_f).round.to_s
    if currency["percent_change_24h"].to_f > 0
      listup << [ mark.green, amount.green, Money.new(price, :jpy).format.green, change_in_24.green , Money.new(sum, :jpy).format.green ]
    else
      listup << [ mark.red, amount.red,  Money.new(price, :jpy).format.red, change_in_24.red , Money.new(sum, :jpy).format.red ]
    end
    total += sum.to_f
  end
  
  range = total - last_total
  logfile.puts(total.to_s)
  t = Time.now
  title = t.strftime("💹 (%y-%m-%d %H:%M)")
  if range > 0
#    @messanger.send('嫩模指数速报'+ title, "过去的5分钟内，资产上涨了#{Money.new(range, :jpy).format}, 现在总资产#{Money.new(total, :jpy).format}") if range > 10000 
    range =  "(+#{Money.new(range.round.to_s, :jpy).format})".green
  else
    # @messanger.send('要饭指数速报'+ title, "过去的5分钟内，资产下跌了#{Money.new(range.abs, :jpy).format}, 现在总资产#{Money.new(total, :jpy).format}") if range < -10000
    range =  "(-#{Money.new(range.round.abs.to_s, :jpy).format})".red
  end
  table = Terminal::Table.new :title => title, :headings => ['币种', '持仓', '单价', '涨跌(24h)', '合计(jpy)'], :rows => listup
  table << ['Total', '','','', Money.new(total.round.to_s, :jpy).format]
  table << ['', '','','', range]  if range != total
  puts table
  logfile.close
end

while true
  puts `clear`
  get_assets
  sleep(300)
end
