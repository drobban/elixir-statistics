defmodule Statistics.Distributions.Normal do
  #use Application.Behaviour

  alias Statistics.MathHelpers, as: Math

  @doc """
  Probability density function
  
  get result of probability density function

  ## Examples
  
      iex> Statistics.Distributions.Normal.pdf(0) 
      0.3989422804014327
      iex> Statistics.Distributions.Normal.pdf(1.3, 0.2, 1)
      0.21785217703255055

  """
  def pdf(x) do
    pdf(x, 0, 1)
  end

  def pdf(x, mu, sigma) do
    numexp = Math.pow((x - mu), 2) / (2 * Math.pow(sigma, 2))
    denom = sigma * Math.sqrt((2 * Math.pi))
    numer = Math.pow(Math.e, (numexp * -1)) 
    numer / denom
  end

  @doc """
  Get the probability that a value lies below `x`
  
  Cumulative gives a probability that a statistic
  is less than Z. This equates to the area of the distribution below Z.
  e.g:  Pr(Z = 0.69) = 0.7549. This value is usually given in Z tables.

  ## Examples

    iex> Statistics.Distributions.Normal.cdf(2)
    0.9772499371127437
    iex> Statistics.Distributions.Normal.cdf(0)
    0.5000000005
                 
  """
  def cdf(x) do
    cdf(x, 0, 1)
  end

  def cdf(x, mu, sigma) do
    0.5 * (1.0 + erf((x - mu) / (sigma * Math.sqrt(2))))
  end

  @doc """
  Draw a random number from a normal distribution

  `rnd/0` will return a random number from a normal distribution
  with a mean of 0 and a standard deviation of 1

  `rnd/3` allows you to provide the mean and standard deviation
  parameters of the distribution from which the random number is drawn

  Uses the [rejection sampling method](https://en.wikipedia.org/wiki/Rejection_sampling)

  ## Examples

      iex> Statistics.Distributions.Normal.rand()
      1.5990817245679434
      iex> Statistics.Distributions.Normal.rand(22, 2.3)
      23.900248900049736

  """
  def rand do 
    rand(0, 1)
  end

  def rand(mu, sigma) do 
    rmu = 0.5
    rsigma = 0.1
    x = :random.uniform()
    y = :random.uniform()
    if pdf(x, rmu, rsigma) > y do
      z = (rmu - x) / rsigma # get z-score
      mu + (z * sigma) # adjust for distribution size
    else
      rand(mu, sigma) # keep trying
    end
  end

  # the error function
  """ 
  from: http://malishoaib.wordpress.com/2014/04/02/python-code-and-normal-distribution-writing-cdf-from-scratch/
  John D. Cook's implementation.http://www.johndcook.com
    >> Formula 7.1.26 given in Abramowitz and Stegun.
    >> Formula appears as 1 – (a1t1 + a2t2 + a3t3 + a4t4 + a5t5)exp(-x2)
    >> A little wisdom in Horner's Method of coding polynomials:
      1) We could evaluate a polynomial of the form a + bx + cx^2 + dx^3 by coding as a + b*x + c*x*x + d*x*x*x.
      2) But we can save computational power by coding it as ((d*x + c)*x + b)*x + a.
      3) The formula below was coded this way bringing down the complexity of this algorithm from O(n2) to O(n).''
  """
  defp erf(x) do
    # constants
    a1 =  0.254829592
    a2 = -0.284496736
    a3 =  1.421413741
    a4 = -1.453152027
    a5 =  1.061405429
    p  =  0.3275911
        
    # Save the sign of x
    sign = if x < 0, do: -1, else: 1
    x = abs(x)
    
    # Formula 7.1.26 given in Abramowitz and Stegun.
    t = 1.0/(1.0 + p*x)
    y = 1.0 - (((((a5*t + a4)*t) + a3)*t + a2)*t + a1) * t * Math.pow(Math.e, (-x*x))
    
    sign * y
  end

end