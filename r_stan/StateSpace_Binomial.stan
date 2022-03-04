//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

//時系列状態空間モデル二項version
data {
  int N;
  int D;
  int K;
  int<lower = 1, upper = D> DATE[N];
  matrix[N,K] V;
  int<lower = 0> M[N];
  int<lower = 0> J[N];
}

transformed data {
  int<lower = 0> SUM[N];
  for(n in 1:N) SUM[n] = M[n] + J[n];
}

parameters {
  real theta[K];
  real<lower = -5, upper = 5> delta0;
  real<lower = 0> sigma[1];
  real<lower = -5, upper = 5> delta[D];
}

transformed parameters {
  vector<lower = 0>[N] mu;
  real v[N,K];
  
  for(k in 1:K)
    for(n in 1:N)
      v[n,k] = theta[k]*V[n,k];

  for (n in 1:N)
    mu[n] = inv_logit(sum(v[n,1:K]) + delta[DATE[n]]);
}


model {
  delta[1] ~ normal(delta0, sigma[1]);
  for (d in 3:D) delta[d] ~ normal(2*delta[d-1] - delta[d-2], sigma[1]);
  for (n in 1:N) M[n] ~ binomial(SUM[n], mu[n]);
}


generated quantities {
 vector[N] pred;
 for (n in 1:N) pred[n] = binomial_rng(SUM[n], mu[n]);
}
