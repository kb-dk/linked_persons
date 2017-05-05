module LP::Aggregatable
  
  SOURCE_URI_ROOTS = [ 'http://www.wikidata.org/', 
                       'https://www.wikidata.org/',
                       'http://viaf.org/',
                       'https://viaf.org/', ].freeze

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods

    def aggregatable?
      true
    end

  end

  def aggregatable?
    true
  end

  def aggregated?
    @aggregated ||= false
  end

  def aggregate

    source_uris.each do |uri|
      # resource = LP::Resource.new(uri, @data)
      resource = LP::Resource.new(uri, RDF::Repository.new)
      
      begin
        resource.dereference
      rescue LP::Errors::AlreadyExists => e
        p e.message
      end

      resource.graph.query([uri, RDF.type, :o]).each do |statement| 
        graph << RDF::Statement(
          subject_uri, 
          RDF.type, 
          statement.object, 
          graph_name: subject_uri)
      end

    end 

    # TODO: Retrieve the relevant information via SPARQL queries. 
    #   solutions = SPARQL.execute("SELECT * WHERE { ?s ?p ?o }", resource.graph).
    #   solutions.each do |sol|
    #     graph << RDF::Statement(sol.s, sol.p, sol.o, graph_name: subject_uri) 
    #   end

    @aggregated = true
  end

  def source_uris
    @source_uris ||= same_as_uris.select do |uri| 
      SOURCE_URI_ROOTS.include? uri.root.to_s
    end
  end



end