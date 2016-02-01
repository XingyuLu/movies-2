#Xingyu Lu
#COSI 166B
#(PA) Movies Part 2

class MovieData
  def initialize(*args)
    @trainSet = File.open("#{args[0]}/u.data").readlines
    #using *args so initialize can take both one or two arguments
    if args.size == 2
      @testSet = File.open("#{args[0]}/#{args[1]}.test").readlines
    else
      @testSet = Array.new
    end

    @usermap = Hash.new         #usermap contains every user's reviews on movies
    @moviemap = Hash.new        #moviemap contains every movie's viewers and their rating on this movie
    @similarity_list = Hash.new    #similarity_list contains similarity bewteen one user and others
    load_data()
  end

  #this method loads data into usermap and moviemap
  def load_data()
    @trainSet.each do |line|
      subline = line.split
      user_id = subline[0].to_i
      movie_id = subline[1].to_i
      rating = subline[2].to_i

      if !(@usermap.has_key?(user_id))
        @usermap[user_id] = Hash.new
      end
      #first we fill up usermap
      @usermap[user_id][movie_id] = rating

      if !(@moviemap.has_key?(movie_id))
        @moviemap[movie_id] = Hash.new
      end
      #then we fill up moviemap
      @moviemap[movie_id][user_id] = rating
    end
  end

  #return the rating on m made by u
  def rating(u,m)
    if @usermap[u].has_key?(m)
      @usrmap[u][m]
    else
      0
    end
  end

  #return the list of movies rated by u
  def movies(u)
    @usermap[u].keys
  end

  #return the list of viewers who rated m
  def viewers(m)
    @moviemap[m].keys
  end

  #return the similarity between user1 and user2
  def similarity(user1, user2)
    count = 0
    similar = 0
    #to make a shorter comparison, we loop on the shorter movie list
    if @usermap[user1].length > @usermap[user2].length
      u1 = user2
      u2 = user1
    else
      u1 = user1
      u2 = user2
    end

    @usermap[u1].each do |m1, r1|
      #if user1 and user2 have both rated one movie m, we compare the rating they made
      #and the difference bewteen these two ratings indicates their similarity. The smaller
      #the difference, the more similar these users are.
      if @usermap[u2].has_key?(m1)
        count += 1
        similar += 5 - (r1 - @usermap[u2][m1]).abs
      end
    end

    if count == 0
      0
    else
      #we calculate the average to get a more convincing similarity constant
      similar/count.to_f
    end
  end

  #this method predicts user u's rating on movie m
  def predict(u,m)
    viewers = viewers(m)
    rating = 0
    count = 0
    most_similar = -1

    #the rating from the user who has rated m and is most similar to user u is
    #our prediction

    #to avoid we repeat computing similarity between two users, we use similarity_list to
    #contain similarity between users.
    if !@similarity_list.has_key?(u)
      @similarity_list[u] = Hash.new
    end

    viewers.each do |viewer|
      similarity = 0
      #if this similarity is already in the similarity_list, we directly access it from the list
      if @similarity_list[u].has_key?(viewer)
        similarity = @similarity_list[u][viewer]
      elsif @similarity_list.has_key?(viewer) &&  @similarity_list[viewer].has_key?(u)
        similarity = @similarity_list[viewer][u]
      else
        #if this similarity is not in the list, we compute it and put it into the list
        similarity = similarity(u, viewer)
        @similarity_list[u][viewer] = similarity
      end

      #then we look for the user who is most similar to user u. If there exists more than one,
      #we average the sum of ratings.
      if similarity > most_similar
        count = 1
        rating = @moviemap[m][viewer]
      elsif similarity == most_similar
        count = count + 1
        rating += @moviemap[m][viewer]
      end
    end

    rating/count.to_f
  end

  #run the test and return a MovieTest object
  def run_test(*args)
    result = Array.new
    k = @testSet.length

    if args.size == 1
      k = args[0]
    end

    for i in 0..k-1
      subline = @testSet[i].split
      user = subline[0].to_i
      movie = subline[1].to_i
      rating = subline[2].to_i
      #make the prediction and put the result into an array
      prediction = predict(user,movie)
      result.push([user,movie,rating,prediction])
    end

    MovieTest.new(result)
  end

end


class MovieTest
  def initialize(result)
    @test = result
  end

  def to_a
    @test
  end

  #calculate the mean of prediction error
  def mean
    sum = 0
    @test.each do |value|
      sum += value[2] - value[3]
    end

    sum/@test.length.to_f
  end

  #calculate the standard deviation of the errors
  def stddev
    sum = 0
    meanerror = mean
    @test.each do |value|
      sum += (value[2] - value[3] - meanerror) ** 2
    end

    Math.sqrt(sum/@test.length.to_f)
  end

  #calculate the root mean square error of the prediction
  def rms
    sum = 0
    @test.each do |value|
      sum += (value[2] - value[3]) ** 2
    end
    Math.sqrt(sum/@test.length.to_f)
  end

end



z = MovieData.new('ml-100k', :u1)
k = z.run_test()
puts k.rms
puts k.mean
