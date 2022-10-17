use dep::std;

fn main(
    nullifier: Field,
    secret: Field,
    nullifierHash: pub Field,
    recipient: pub Field
) {
    let r = commitmentHasher(nullifier, secret);
    constrain r[1] == nullifierHash;
    constrain recipient == recipient;
}

fn commitmentHasher(nullifier: Field, secret: Field) -> [Field; 2] {
    let commitment = std::hash::pedersen([nullifier, secret]);
    let nullifierHash = std::hash::pedersen([nullifier]);
    [commitment[0], nullifierHash[0]]
}