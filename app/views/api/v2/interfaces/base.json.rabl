object @interface

attributes :id, :name, :ip, :mac, :identifier
node :type do |i|
  i.class.humanized_name.downcase
end
