
class SearchController < ApplicationController

  def index()


	  @arrA =[]
	  intB = 0
	  intI = 0
    @array = params    
    
    filename = File.expand_path(Rails.root.join('public', 'files','somefile.pdf')) # File handle 

    PDF::Reader.open(filename) do |reader| #Gem pdf-reader
      reader.pages.each do |page|
        #puts page.text
        #@a[i++] = page.text
        @arrA << page.text
      end #reader
    end # PDF:Reader

@strWord = {}

    @arrA.each do |page,index|

      @strWord["page#{intI}"] = page
      intI = intI + 1
        
    end
     p '================================================================' 
     puts @strWord.first
   	@str = "<pre>#{}</pre>".html_safe
    @str1 = "<hr></hr>".html_safe



     puts @strWord

  end # END OF FUN index()

  def read()

    

  end #END OF FUN read()

end
