class FileManagersController < ApplicationController

  def home 

  end 		
  def index


  	   uploaded_io_arr = params
		p "£"*10 
		(1..5).each do |k|
			if uploaded_io_arr["file#{k}"].present?
  	   			fn  = uploaded_io_arr["file#{k}"].original_filename
  	   			if 0 != self.file_check(fn)
  	   				
  	   			end 
  	   		end 	
  	  	end 

		#p uploaded_io_arr
	#	p  request.headers["CONTENT_TYPE"]
		#uploaded_io_arr = uploaded_io_arr.split(',')
		#p uploaded_io[0]
      
	  	
  		@f = []	
	  @arrCorpus = {}
	  @arrDir = Dir.glob("public/files/*")
	  @arrDir.each do |file1|
	  	@filepdf = file1.split('/')
	  	@f << @filepdf[2]
      end

  	doc = [{:key=>"Document1.pdf", :value=>{"new"=>1, "york"=>1, "times"=>1}}, {:key=>"Document2.pdf", :value=>{"new"=>1, "york"=>1, "post"=>1}}, {:key=>"Document3.pdf", :value=>{"los"=>1, "angeles"=>1, "times"=>1}}]

  	doc_num = 3 #COUNT DOC 
  		obj = Tf_idf_hash.new(doc, doc_num)
  		obj.tf_idf( obj.tf() ,obj.idf() )
  		
  end


def bubble_chart 
	  fileHash = {}
	  @arrCorpus = {}
	  p "$"*10 
	  (1..5).each do |k|
		  if params["file#{k}"].present? 
		  		if 1 == self.file_check(params["file#{k}"].original_filename)
		  			break
		  		else 
		  			p "%"*10
		  			@arrA = [] 
		  			file = params["file#{k}"].original_filename
		  			filePath = params["file#{k}"].tempfile.path
		  			p fh = File.open(filePath)
					PDF::Reader.open(fh) do |reader| #Gem pdf-reader
					reader.pages.each do |page|
						@arrA << page.text
					end #reader
					end # PDF:reader
					@strFullReadStringDoc = @arrA.join(" ") 
					@corpus = self.term_count(@strFullReadStringDoc) 
					@arrCorpus[file] =  @corpus 
		  		end 	
		  end 	
	  end 

	  self.json_write_bubble(@arrCorpus)
	 


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
	   @arrStop_words = File.read(Rails.root.join('app','assets', 'stop_words', 'google_stop_words_2014.txt')).split

	   @flag = 0 
	   @arrStop_words.each do |stop_words|
       			if stop_words == word.to_s
       				@flag =1  
       				break
       			end  
       end 
      return  @flag
end 

def term_count(doc1)
    @doc1 = doc1
    document1 = TfIdfSimilarity::Document.new(@doc1)
    @corpus = []
    @corpus = document1.term_counts
    @corpus = @corpus.sort_by {|_key, value| value}
    @corpus = @corpus.reverse
    return @corpus
 end 



 def new
 	#QUERY 

if request.post?
	@arrA = []
	@arrA1 = []

	@filename_n_wordcount = []
	@filename_n_wordcount1 = []

 	file_count  = 0

 	if params["query"].present? 
 		@quName = params["query"].original_filename
 		if 1 == self.file_check(params["query"].original_filename)
		   p "query required"
		 else 
		 		file1 = params["query"].original_filename
		  		filePath1 = params["query"].tempfile.path
 					fh1 = File.open(filePath1)
					PDF::Reader.open(fh1) do |reader| #Gem pdf-reader
					reader.pages.each do |page|
						@arrA1 << page.text
					end #reader
					end # PDF:reader
					p "@arrA1"*10 

					@strFullReadStringDoc1 = @arrA1.join(" ") 
					p @strFullReadStringDoc1
						hash = {:key => file1, :value => @strFullReadStringDoc1}
						document1 = TfIdfSimilarity::Document.new(hash[:value])
						term_n_counts = document1.term_counts
						@data1 = {:key => file1, :value => term_n_counts}
						@filename_n_wordcount1 << @data1
 		end 
 	end 
 #p "$£"*10 
  @query = @filename_n_wordcount1

 	#FILES 
 	(1..5).each do |k|
		  if params["file#{k}"].present? 
		  		if 1 == self.file_check(params["file#{k}"].original_filename)
		  			break
		  		else 
		  		file = params["file#{k}"].original_filename
		  		filePath = params["file#{k}"].tempfile.path
		  		file_count  = file_count + 1
		  		fh = File.open(filePath)
					PDF::Reader.open(fh) do |reader| #Gem pdf-reader
					reader.pages.each do |page|
						@arrA << page.text
					end #reader
					end # PDF:reader
					@strFullReadStringDoc = @arrA.join(' ') 
						hash = {:key => file, :value => @strFullReadStringDoc}
						document1 = TfIdfSimilarity::Document.new(hash[:value])
						term_n_counts = document1.term_counts
						@data = {:key => file, :value => term_n_counts}
						@filename_n_wordcount << @data
		  		end 
		  end 
	end 
	# FILES END 
 	@doc_num = file_count
	p @out = self.sim( @filename_n_wordcount ,@doc_num ,   @query )
	
	@out = @out.sort_by {|_key, value| value}



end 
 end # FUNCITON 

 def sim(filename_n_wordcount ,doc_num , query )
=begin

 	tf_idf = {
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

=end
#p "DOC #{doc_num} OUT #{filename_n_wordcount} "


=begin

 	@query =  {
			"Document1.pdf"=>
					{"los"=>0.477085, "angeles"=>0.477085, "times"=>0.0, "new"=>0.0, "york"=>0.0, "post"=>1.585}
			 }
=end
	objQuery = Tf_idf_hash.new(query , 1)
	query  = 	objQuery.tf_idf( objQuery.tf(), objQuery.idf() )


 	objTf_idf = Tf_idf_hash.new(filename_n_wordcount, doc_num)

 	 objTf_idf.tf()
 	p "!"*10
	 objTf_idf.idf()
 	 tf_idf = 	objTf_idf.tf_idf( objTf_idf.tf(), objTf_idf.idf() )
 	objCsh =Cosine_similarity_hash.new
 	return  cosine = objCsh.cosine_sim(tf_idf , query)
 	 
 end 



def file_check(file_arr)
	
	mime_type = MIME::Types.type_for(file_arr).first.content_type
	 if mime_type != "application/pdf"
	 		flash1 =  "ONLY PDF FILES ARE ALLOWED, FILE #{file_arr} IS NOT A PDF" 
  	   		flash[:notice] = flash1
  	   		return 1
	 end
	 return 0  		
	  
end 


end
