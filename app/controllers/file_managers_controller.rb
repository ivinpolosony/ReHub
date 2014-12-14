class FileManagersController < ApplicationController
  def index


  	   uploaded_io_arr = params
		p "£"*10 
		(1..5).each do |k|
			if uploaded_io_arr["file1"] 
  	   			p uploaded_io_arr["file1"].original_filename
  	   		end 	
  	  	end 

		#p uploaded_io_arr
	#	p  request.headers["CONTENT_TYPE"]
		#uploaded_io_arr = uploaded_io_arr.split(',')
		#p uploaded_io[0]
      self.file_check(uploaded_io_arr)
	  	
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
	  @f = []	
	  @arrCorpus = {}
	  @arrDir = Dir.glob("public/files/*")
	  @arrDir.each do |file1|
	  	@filepdf = file1.split('/')
	  	@f << @filepdf[2]
      end

      if request.post?
	    @arrSelectedFiles = params[:file]
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

 	@arrSelectedFiles = ["Document2.pdf", "Document1.pdf", "Document3.pdf" ] 

 	@filename_n_wordcount = []
	    @value = []
	    @value = @arrSelectedFiles
	    @doc_num = @arrSelectedFiles.length
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

	        hash = {:key => @fileName, :value => @strFullReadStringDoc}
	        document1 = TfIdfSimilarity::Document.new(hash[:value])
	        term_n_counts = document1.term_counts
	        @data = {:key => @fileName, :value => term_n_counts}

	      @filename_n_wordcount << @data

	     end 
#p @filename_n_wordcount.length


p	 @out = self.sim( @filename_n_wordcount ,@doc_num  )
 end 

 def sim(filename_n_wordcount ,doc_num)

=begin
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


=end

 	@query =  {
			"Document1.pdf"=>
					{"los"=>0.477085, "angeles"=>0.477085, "times"=>0.0, "new"=>0.0, "york"=>0.0, "post"=>1.585}
			 }
 	objTf_idf = Tf_idf_hash.new(filename_n_wordcount, doc_num)
 	 tf_idf = 	objTf_idf.tf_idf( objTf_idf.tf(), objTf_idf.idf() )
 	objCsh =Cosine_similarity_hash.new
 	 cosine = objCsh.cosine_sim(tf_idf , @query)
 	 
 end 



def file_check(file_arr)
	p "FILE"*10
	    MIME::Types.type_for("filename.gif").first.content_type
		

end 


end
