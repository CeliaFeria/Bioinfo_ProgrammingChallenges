
require "./Web_info.rb"

class Network
  
:Interactions
:GO_info
:KEGG_info 

#@@Interaction_Network = []
@interacctions = Hash.new
  
  

  
def initialize (params={})
    @Interaction = params.fetch(:Interactions, "ABC")
    @GO_info = params.fetch(:GO_info, "ABC")
    @KEGG_info = params.fetch(:KEGG_info, "ABC")
  
end
  
  
def Network.information(info)
  info.each do |key, value|
  all = Network.new({:Interactions => info[key], 
    :GO_info => get_GO(value), 
    :KEGG_info =>  get_KEGG_info(key)})
      
    @interacctions[key] = all
  end
end 
  
  def Network.all_info
    return @interacctions
  end
  
end 


