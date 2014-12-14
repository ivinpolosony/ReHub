class UploadController < ApplicationController

  def index 
    #render :file => 'app\views\upload\uploadfile.rhtml'
    #Displays the file name for the check boxes 
   @arrDir = Dir.glob("public/files/*")
    @f = []
    @arrCorpus = {}
    @FullTerms = []
    @arrDir.each do |file1|
    	@filepdf = file1.split('/')
   		@f << @filepdf[2]
    end
    #END =====> Displays the file name for the check boxes 
   @arrStop_words = File.read(Rails.root.join('app','assets', 'stop_words', 'google_stop_words_2014.txt')).split



    if request.post?

	    @arrSelectedFiles = params[:file]
	    @value = []
		#p '%'*19
		#p @arrSelectedFiles.inspect		
		
		@value = @arrSelectedFiles
		p "FILE COUNT  ===========> #{@arrSelectedFiles.length}" 

		@intDocument_Count = @arrSelectedFiles.length
=begin

=end


		# FILE NAME ITERATION 
		  # ITERATION OF FILES  
		@value.each do |fname|
		  	uploaded_io = fname

	        @fileName = uploaded_io
	        fileHandle = File.expand_path(Rails.root.join('public', 'files', @fileName)) # File handle
	        @arrA = []
	        PDF::Reader.open(fileHandle) do |reader| #Gem pdf-reader
	          reader.pages.each do |page|
	            @arrA << page.text
	          end #reader
	        end # PDF:reader
	         @strFullReadStringDoc = @arrA.join(" ") 
	         @corpus = self.term_count(@strFullReadStringDoc) 
    		# p '^'*60 
    		# p fname


			 @FullTerms << @corpus     
	         @arrCorpus[fname] =  @corpus 
	#         p "!!"*10 
	         

	         @arrFrequency_Weights = self.term_frequency_weights(@corpus)
	         @corpus = @arrFrequency_Weights

		 end # each fname 
    end # if 
  
    # REDUCE PHASE 
    @totalWords = {}
    @cnt = 0 
    @FullTerms.each_with_index do |value , key |
    	value.each_with_index do |value1 , key1|
    		if "nil" != @totalWords.find{|key,value| key == "#{value1[0]}"}
    		 @totalWords[value1[0]]  = 0
    		end  
    	end  
    end  

@newHash = {}


    @FullTerms.each_with_index do |value , key |
    	value.each_with_index do |value1 , key1|
		@totalWords.each_with_index do |word , count , index |	
			p "#{word}"
			if value1[0] == word 
				@totalWords[:word] = @totalWords[:word] + value1[1] 			
			end
		end  		
		end 
	end 


#p @totalWords.find{|key,value| key == "tasdasdhe"}
p @totalWords.inspect
		
 	# REDUCE PHASE ENDS



    @hashFullWord_vs_File = []
    @arrCorpus.each do |val|
	#    p '^'*60 
    	fileN =  val[0] 
    	val[1].each_with_index do |v,i|
    	#	p '===VAL[1]=='*10
    	#	p "v ====> #{v[0]} i =====> #{i}"
    		word = v[0]
    		cnt = v[1] 
    		
    		@hashFullWord_vs_File << {word => { fileN => cnt}} 

    	end 
    end  
    #p "~hash"*10
    h1 = {}
    #p @hashFullWord_vs_File.length
    #p @hashFullWord_vs_File.inspect

    

	




    




  end


  def uploadFile



    uploaded_io = params[:file]
    File.open(Rails.root.join('public', 'files', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
      @fileName = uploaded_io.original_filename

    end #File.open
    	flash[:notice] = "You have Successfully Uploaded ===> #{
    	@fileName} to our database"

  end #uploadFile



 def term_count(doc1)
    @doc1 = doc1
    document1 = TfIdfSimilarity::Document.new(@doc1)
    @corpus = []
    @corpus = document1.term_counts
    @corpus = @corpus.sort_by {|_key, value| value}
    @corpus = @corpus.reverse
    return @corpus
 end 

 def term_frequency_weights(term_count)
 	term_frequency_weights = {}	
 	term_count.each_with_index do |value,index|
		term_frequency_weights[value[0]] = Math.log10(value[1]+1).round(3)

		


 	end 
 	return term_frequency_weights 
 end


def idf()


end 

def bubble_chart 
	  @f = []	
	  @arrCorpus = {}
	  @arrDir = Dir.glob("public/files/*")
	  @arrDir.each do |file1|
	  	@filepdf = file1.split('/')
	  	@f << @filepdf[2]
      end

      if request.post?
	    p @arrSelectedFiles = params[:file]
	    @value = []
	    @value = @arrSelectedFiles
	  # FILE NAME ITERATION 
		  # ITERATION OF FILES  
		@value.each do |fname|
		  	uploaded_io = fname
	        @fileName = uploaded_io
	        fileHandle = File.expand_path(Rails.root.join('public', 'files', @fileName)) # File handle
	        @arrA = []
	        PDF::Reader.open(fileHandle) do |reader| #Gem pdf-reader
	          reader.pages.each do |page|
	            @arrA << page.text
	          end #reader
	        end # PDF:reader
	        @strFullReadStringDoc = @arrA.join(" ") 
	        @corpus = self.term_count(@strFullReadStringDoc) 
    		@arrCorpus[fname] =  @corpus 
          
		 end # each fname
		 self.json_write_bubble(@arrCorpus)  
		 flash[:notice] = @arrSelectedFiles
	  end # if POST  

end 


def json_write_bubble(arrCorpus)
	@arrCorpus = arrCorpus
    @childcomma = ','
    @FileComma = ','
    @strJson = ''
    @strJson.concat('{
		 "name": "flare",
		 "children": [

		  ')
    @i = 1 

    @arrCorpus.each do |v|
    	file =  v[0]
    	@strJson.concat('
		   {
		   	"name": "'+file+'",
		   "children": [
		    ')
    	@cnt = 1
       	v[1].each do |hash_word_cnt|
       		
       		# STOP WORD REMOVAL FLAG 
       		if 1 == self.stop_words(hash_word_cnt[0].to_s) 
       			next 
       		end 
		 @strJson.concat('{"name": "'+ hash_word_cnt[0].to_s + '==> '+file+'", "size":'+hash_word_cnt[1].to_s+' }
		   
			')
		# TOP FIVE 
		if @cnt == 5
		 	break
		end
		@cnt = @cnt + 1	 
		if hash_word_cnt != v[1].last 
				  @strJson.concat(' ,') 
		end   
	    end 
	 	@strJson.concat('

			]
		  }	
		
		')
		#	break 
		if @i != @arrCorpus.length
				  @strJson.concat(' ,') 
    	end 	
		 @i = @i + 1	
	end 
	@strJson.concat(	']
	}' )

    File.open(Rails.root.join('app','assets', 'json', 'flare.json'), 'wb') do |file|
      file.write(@strJson)
    end 	
end 

def load
        @data = File.read("app/assets/json/flare.json")
        render :json => @data
end

def stop_words(word)
	 p  @arrStop_words = File.read(Rails.root.join('app','assets', 'stop_words', 'google_stop_words_2014.txt')).split

	   @flag = 0 
	   @arrStop_words.each do |stop_words|
       			if stop_words == word.to_s
       				@flag =1  
       				break
       			end  
       end 
      return  @flag
end 


def idf(data,doc_num)
@data = data
@word_n_count= []
@data.each do |hash|
@word_n_count << hash[:value]

hash = []
@word_n_count.flat_map(&:entries).group_by(&:first).map{|k,v|
hash << [k, v.map(&:last)]
p values = Hash[hash]
arr_of_counts = values.values
arr_of_counts.each do |o|
@value = o.inject {|sum,n| sum + n} # add all the count values together
@idf = Math.log(doc_num/@value)
end
@myhash = {@key => @idf}
}


end
end


def cosine_sim()

=begin

  	doc = [{:key=>"Document1.pdf", :value=>{"new"=>1, "york"=>1, "times"=>1}}, {:key=>"Document2.pdf", :value=>{"new"=>1, "york"=>1, "post"=>1}}, {:key=>"Document3.pdf", :value=>{"los"=>1, "angeles"=>1, "times"=>1}}]

  	doc_num = 3 #COUNT DOC 

#  		obj = Tf_idf_hash.new(doc, doc_num)


  		p obj.tf_idf( obj.tf() ,obj.idf() )
=end


	@tf_idf = {
			"Document1.pdf"=>
					{
					"new"=>0.584, 
					"york"=>0.584, 
					"times"=>0.584, 
					"post"=>0.0, 
					"los"=>0.0, 
					"angeles"=>0.0,
					
					}, 
		    "Document2.pdf"=>
		    		{
		    		"new"=>0.584, 
		    		"york"=>0.584, 
		    		"post"=>1.584, 
		    		"times"=>0.0, 
		    		"los"=>0.0, 
		    		"angeles"=>0.0
		    		}, 
		    "Document3.pdf"=>
			    {
			    	"los"=>1.584, 
			    	"angeles"=>1.584, 
			    	"times"=>0.584, 
			    	"new"=>0.0, 
			    	"york"=>0.0, 
			    	"post"=>0.0
			    }
		    }

	@doc_length = {
					"Document1.pdf"=> 1.011, 
					"Document2.pdf"=>1.786, 
					"Document3.pdf"=>2.316
				   }

	p @doc_length = self.length(@tf_idf)



	@query =  {
			"Document1.pdf"=>
					{
					"new"=>0.584, 
					"york"=>0.0, 
					"times"=>0.292, 
					"post"=>0.0, 
					"los"=>0.0, 
					"angeles"=>0.0
					}
			 }


	@query_doc_length = {
							"Document1.pdf"=>0.652
						}
	p @query_doc_length = self.length(@query)					

	@arrCosine = [] 

	#p "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP #{@query.values}"

	@denominator = {} 
	@sum = 0.0

	#p @query["Document1.pdf"] 
 	@mult = 0 
=begin
	@query.each do |value_h| 
		value_h[1].keys.each do  |word|
			# query

			@tf_idf.each do |hash| #docs 
				hash[1].each do |word_cnt|
					if word_cnt[0] == word
	   				    @query["#{value_h[0]}"]["#{word}"]
						@mult = @query["#{value_h[0]}"]["#{word}"].to_f * word_cnt[1].to_f
						@sum = @sum + @mult  	
					end 
					p "SUM #{@sum}"
				end 	
				p "SUMout #{@sum}"
					break
								
			end		#doc end 
		
		end 	
	end 
=end
	@hashCosine = {}

	@tf_idf.each do |hash| #docs 
		docname = hash[0]
		word_cnt_hash = hash[1]
		sum = 0 
		word_cnt_hash.each do |word_cnt|
			word = word_cnt[0]
			count = word_cnt[1]
			if @query.values.first.has_key?("#{word}")
				 mult = @query.values.first["#{word}"].to_f * count.to_f 
				 sum = sum + mult
			end 	
		end
		 doc_length	= @doc_length["#{docname}"]
		 query_length  =   @query_doc_length.values[0]
		 deno = doc_length* query_length
		@hashCosine["#{docname}"] = sum/deno 

	end 

	p @hashCosine

end 

def length()
	@tf_idf = {
			"Document1.pdf"=>
					{
					"new"=>0.584, 
					"york"=>0.584, 
					"times"=>0.584, 
					"post"=>0.0, 
					"los"=>0.0, 
					"angeles"=>0.0,
					
					}, 
		    "Document2.pdf"=>
		    		{
		    		"new"=>0.584, 
		    		"york"=>0.584, 
		    		"post"=>1.584, 
		    		"times"=>0.0, 
		    		"los"=>0.0, 
		    		"angeles"=>0.0
		    		}, 
		    "Document3.pdf"=>
			    {
			    	"los"=>1.584, 
			    	"angeles"=>1.584, 
			    	"times"=>0.584, 
			    	"new"=>0.0, 
			    	"york"=>0.0, 
			    	"post"=>0.0
			    }
		    }

	@hashLength = {}
	


		    @tf_idf.each do |hash| #docs 
		    	docname = hash[0]
				word_cnt_hash = hash[1]
				sum = 0
				word_cnt_hash.each do |word_cnt|
					 word = word_cnt[0]
					 count = word_cnt[1]
					sqr = count**2
					sum = sum + sqr  
				end
				@hashLength["#{docname}"] = Math.sqrt(sum)  
		    end 


		p    @hashLength
end 



end # Class 
 