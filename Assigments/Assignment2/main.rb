
require "./Network.rb"
require "./Web_info.rb"

Network.information(get_Network(get_complex_interactions(get_AGI_Locus('./ArabidopsisSubNetwork_GeneList.txt'))))
Network.all_info
Network.report


