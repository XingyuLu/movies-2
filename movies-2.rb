class MovieTest
  def initialize(result)
    @test = result
  end

  def to_a
    @test
  end

  def mean
    sum = 0
    @test.each do |value|
      sum += value[2] - value[3]
    end

    sum/@test.length.to_f
  end

  def stddev
    sum = 0
    meanerror = mean
    @test.each do |value|
      sum += (value[2] - value[3] - meanerror) ** 2
    end

    Math.sqrt(sum/@test.length.to_f)
  end

  def rms
    sum = 0
    @test.each do |value|
      sum += (value[2] - value[3]) ** 2
    end
    Math.sqrt(sum/@test.length.to_f)
  end

end


class MovieData
  def initialize(*args)
    @trainSet = File.open("#{args[0]}/u.data").readlines

    if args.size == 2
      @testSet = File.open("#{args[0]}/#{args[1]}.test").readlines
    else
      @testSet = Array.new
    end

    @usermap = Hash.new
    @moviemap = Hash.new
    load_data()
  end

  def load_data()
    @trainSet.each do |line|
      subline = line.split
      user_id = subline[0].to_i
      movie_id = subline[1].to_i
      rating = subline[2].to_i
      if !(@usermap.has_key?(user_id))
        @usermap[user_id] = Hash.new
      end

      @usermap[user_id][movie_id] = rating

      if !(@moviemap.has_key?(movie_id))
        @moviemap[movie_id] = Hash.new
      end

      @moviemap[movie_id][user_id] = rating
    end
  end

  def rating(u,m)
    if @usermap[u].has_key?(m)
      @usrmap[u][m]
    else
      0
    end
  end

  def movies(u)
    @usermap[u].keys
  end

  def viewers(m)
    @moviemap[m].keys
  end

  def similarity(user1, user2)
    count = 0
    similarity = 0
    if @usermap[user1].length > @usermap[user2].length
      u1 = user2
      u2 = user1
    else
      u1 = user1
      u2 = user2
    end

    @usermap[u1].each do |m1, r1|
      if @usermap[u2].has_key?(m1)
        count = count + 1
        similarity += 5 - (r1 - @usermap[u2][m1]).abs
      end
    end

    if count == 0
      0
    else
      similarity/count.to_f
    end

  end

  def predict(u,m)
    viewers = viewers(m)
    rating = 0
    count = 0
    most_similar = -1
    viewers.each do |viewer|
      similarity = similarity(u, viewer)
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
      prediction = predict(user,movie)
      result.push([user,movie,rating,prediction])
    end

    MovieTest.new(result)
  end

end

z = MovieData.new('ml-100k', :u1)
k = z.run_test(100)
puts k.mean
