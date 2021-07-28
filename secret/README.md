## Precondition
```bash
brew install shyiko/kubesec/kubesec
brew install sops
brew install gnupg
```


## Generate GPG Key
`Realm: kboot`

```bash
gpg --gen-key

gpg (GnuPG) 2.2.20; Copyright (C) 2020 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Note: Use "gpg --full-generate-key" for a full featured key generation dialog.

GnuPG needs to construct a user ID to identify your key.

Real name: kboot
Email address: 
You selected this USER-ID:
    "kboot"

Change (N)ame, (E)mail, or (O)kay/(Q)uit? o
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: /Users/morpheus/.gnupg/trustdb.gpg: trustdb created
gpg: key DD1DA34FC62DD71B marked as ultimately trusted
gpg: directory '.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '.gnupg/openpgp-revocs.d/A978A4B262D53DD1DA34FC62DD71B.rev'
public and secret key created and signed.

pub   rsa2048 2020-05-29 [SC] [expires: 2022-05-29]
      A978A4B262D53DD1DA34FC62DD71B
uid                      kboot
sub   rsa2048 2020-05-29 [E] [expires: 2022-05-29]
```

## List
```bash
gpg --list-secret-keys

gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   2  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 2u
gpg: next trustdb check due at 2022-05-29
.gnupg/pubring.kbx
----------------------------------
sec   rsa2048 2020-05-29 [SC] [expires: 2022-05-29]
      F4192D48D4DA978A4B262D53DD1DA34FC62DD
uid           [ultimate] myhelsana <myhelsana@helsana.ch>
ssb   rsa2048 2020-05-29 [E] [expires: 2022-05-29]

sec   ed25519 2021-07-11 [SC] [expires: 2023-07-11]
      0C24CECB4650AA68DCF1CA8C63CFE04AF5A43
uid           [ultimate] kboot
ssb   cv25519 2021-07-11 [E] [expires: 2023-07-11]

```

## Export Private Key
```bash
gpg --export-secret-keys kboot > kboot-private-key.asc
```

## Export Public Key
```bash
gpg --armor --export kboot > kboot-pubkey.asc
```

## find the public fingerprint
```bash
gpg --list-keys "kboot" | grep pub -A 1 | grep -v pub
      D4DA978A4B262D53DD1DA34FC62DD
```

## Import Key
```bash
gpg --import kboot-private-key.asc
```

# Create Secret
## spring-encrypt
### Create Secret form file with kubesec
Create `local.secret` file with your secret eg. `justAVerySecureSecretUsedForKubesec`.
```bash
vi local.secret  
```

### kubesec create
```bash
 kubesec c spring-encrypt \
    -a component=spring-boot \
    -a version=$(git rev-parse --short HEAD) \
    -l secret=kboot-infra \
    -d user=admin \
    -d file:key=local.secret \
    > secret.enc.yaml
```
 

Enter the password
```bash

       ┌────────────────────────────────────────────────────────────────┐
       │ Please enter the passphrase to unlock the OpenPGP secret key:  │
       │ "kboot <>"                             │
       │ 2048-bit RSA key, ID DD1DA34FC62DD71B,                         │
       │ created 2020-05-29.                                            │
       │                                                                │
       │                                                                │
       │ Passphrase: *********_________________________________________ │
       │                                                                │
       │         <OK>                                    <Cancel>       │
       └────────────────────────────────────────────────────────────────┘
```

### Deploy Secret with kubesec
```bash
kubesec decrypt secret.enc.yaml | kubectl apply -n kboot -f -
```

### Check Secret Values
```bash
k get secrets -l 'secret in (kboot-infra)' -n kboot -ojson | jq '.items[].data'
{
  "key": "dDJzS5UzRlUzNldC",
  "user": "YWRtaW"
}
```

## Delete GPG
```bash
gpg --delete-secret-keys kboot
```



References:
- https://github.com/shyiko/kubesec
- https://blog.stack-labs.com/code/keep-your-kubernetes-secrets-in-git-with-kubesec/
- https://poweruser.blog/how-to-encrypt-secrets-in-config-files-1dbb794f7352

 






