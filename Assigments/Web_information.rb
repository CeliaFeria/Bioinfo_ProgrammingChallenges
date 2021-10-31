
require 'rest-client' 

def fetch(url, headers = {accept: "*/*"}, user = "", pass="")
  response = RestClient::Request.execute({
    method: :get,
    url: url.to_s,
    user: user,
    password: pass,
    headers: headers})
  return response
  
  rescue RestClient::ExceptionWithResponse => e
    $stderr.puts e.inspect
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue RestClient::Exception => e
    $stderr.puts e.inspect
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue Exception => e
    $stderr.puts e.inspect
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
end 



def get_AGI_Locus(path)
  locus_code= []
  locus = File.open(path, mode: 'r')
  locus.readlines[1..30].each do |line|
    code = line.strip.split("\n")
  locus_code |= code
  end 
  return locus_code
end  

def get_interacction(all_locus)
  interacctions = Hash.new
  #all_int_gen = Hash.new

    all_locus.each do |locus|
    res = fetch("http://bar.utoronto.ca:9090/psicquic/webservices/current/search/interactor/#{locus}/?firstResult=0&maxResults=30&format=tab25");  #restritions: 9090-> species, maxresult -> 30
    body = res.body.split("\n") #each interaction is separated by \n
      #puts locus
    all_interacctions = []
    all_int_gen = Hash.new
    body.each do |elem|
      elem = elem.split("\t")
      elem[-1].to_s =~ /(\d.\d+)/
      score = $1
      if score.to_f > 0.5  #significative medium-high interaction above 0.4
        elem[2] =~ /(A[Tt]\d[Gg]\d\d\d\d\d)/
        gen1 = $1
        elem[3] =~ /(A[Tt]\d[Gg]\d\d\d\d\d)/
        gen2 = $1
        next if gen1.nil?||gen2.nil?
        #puts gen1,gen2

        if gen1.upcase != locus.upcase #I use upcase because all locus have a T instead of the t in the gen interactors
          all_interacctions.push(gen1)
        else
          all_interacctions.push(gen2)
        end 
      end
    end
    next if all_interacctions[0].nil?
    all_int_gen[locus] = all_interacctions
    #puts "primeras interacciones"
    #puts all_int_gen
    #puts "--------------"
    
    include_int = []
    new_int = Hash.new
  
   all_int_gen.each do |key1, locus2|
    locus2.each do |locus_2|
    res = fetch("http://bar.utoronto.ca:9090/psicquic/webservices/current/search/interactor/#{locus_2}/?firstResult=0&maxResults=30&format=tab25");  #restritions: 9090-> species, maxresult -> 30
    body = res.body.split("\n") #each interaction is separated by \n
    interac_2 = []
    all_int_2 = Hash.new
    body.each do |elem|
      elem = elem.split("\t")
      elem[-1].to_s =~ /(\d.\d+)/
      score = $1
      if score.to_f > 0.5  #significative medium-high interaction above 0.4
        elem[2] =~ /(A[Tt]\d[Gg]\d\d\d\d\d)/
        gen1 = $1
        elem[3] =~ /(A[Tt]\d[Gg]\d\d\d\d\d)/
        gen2 = $1
        next if gen1.nil?||gen2.nil?
        #puts gen1,gen2

        if gen1.upcase != locus_2.upcase && gen1.upcase != locus.upcase #I use upcase because all locus have a T instead of the t in the gen interactors
          interac_2.push(gen1)
        else
          if gen2.upcase != locus.upcase
          interac_2.push(gen2)
          end
        end 
      end
    end
    next if interac_2[0].nil?
    all_int_2[locus_2] = interac_2
     #print("second interacctions\n")
    #puts all_int_2
     
    all_int_2.each do |key, values|
      all_locus = all_locus.map{|x| x.upcase}
        if all_locus.include?(key.upcase)
          if key.upcase != locus.upcase  
          print("included another gen on the list\n")
          interacctions[key1] = [key]
          end
        end
    
      values.each do |value|
        if all_locus.include?(value.upcase)
          if value.upcase != key.upcase 
          #print("included\n")
          next if include_int.include?(value)
          include_int.push(value)
            #puts include_int
            new_int[key] = include_int
            #puts new_int
          end
          #puts new_int
      end
    
    end
            next if new_int[key].nil?
            interacctions[key1]= new_int
            #puts "\ngetting interacctions"
            #puts interacctions
            #puts "---------"
        end

  end

end 
  end
return interacctions
end 


def get_Network(interactions)
  puts interactions.keys
  interactions_keys = interactions.keys.map{|x| x.upcase}
  puts interactions_keys
  interactions.each do |key, values|
    values.each do |key2, values2|
      #puts values2
      values2.each do |value2|
      if interactions_keys.include?(value2.upcase)
        bigger_int = interactions.keys.select{|x| x.upcase == value2.upcase} 
        #puts bigger_int[0]
         index = interactions[key][key2].index(value2)
         #puts index
         puts interactions[bigger_int[0]]
         interactions[key][key2][index] = {bigger_int[0] => interactions[bigger_int[0]]}
         interactions[bigger_int[0]] = NilClass
         interactions.reject! { |key, value| value == NilClass }
         
      end 
    end
  end
  end
   puts interactions
  return interactions
end

def get_KEGG_info (locus)
  
  #locus.each do |locus|
  res = fetch("http://togows.org/entry/genes/ath:#{locus}/pathways.json");  #ath = Arabidopsis thaliana
  body = JSON.parse(res.body)
  return body
  #end
end 


def get_GO (locus)
  #locus.each do |locus|
  go_info = []
  res = fetch("http://togows.org/entry/uniprot/#{locus}/dr.json"); 
  #body = res.body
  body = JSON.parse(res.body)
  #puts body
  for elem in body[0]["GO"].each
    if elem[1] =~ /^P:/
    go_info.push(elem[1])
    #end
  end
  end
  return go_info
end 
      


