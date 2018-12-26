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

  date = Date.today.strftime("%Y%m%d")

  t = Time.now

  CSV.foreach( __dir__ + "/config_stock.csv") do |row|
    # BTC,1
    # ETH,40
    code = row[0]
    position[code] = row[1]
    respose = HTTParty.get("https://minkabu.jp/json/stocks/#{code}/prices/1d/#{date}.json")
    data << JSON.parse(respose.body)
    t = JSON.parse(respose.body)["prices"][-1]["pricedAt"]
  end

  title =Time.parse(t).strftime("💹 (%y-%m-%d %H:%M)")
  total = 0
  listup = []
  data.each do |record|
    code = record["brand"]["code"]
    name = record["brand"]["shortName"]
    amount = position[code]
    price = record["prices"][-1]["close"]
    yesterday_price = record["lastPrice"]["close"]
    change_in_24 = price.to_i - yesterday_price.to_i
    sum = change_in_24 * amount.to_i

    if change_in_24 > 0
      listup << [ code.red, name.red, Money.new(price, :jpy).format.red, change_in_24.to_s.red , amount.red, Money.new(sum.to_s, :jpy).format.red ]
    else
      listup << [ code.green, name.green, Money.new(price, :jpy).format.green, change_in_24.to_s.green , amount.green, Money.new(sum.to_s, :jpy).format.green ]
    end
    total += sum
  end
  table = Terminal::Table.new :title => title, :headings => ['代号', '名称', '价格', '涨幅', '持仓', '合计(jpy)'], :rows => listup
  table << ['Total', '','','','', Money.new(total.round.to_s, :jpy).format]
  puts table

end

while true
  puts `clear`
  get_assets
  sleep(60)
end
