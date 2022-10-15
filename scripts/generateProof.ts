
import { compile, acir_from_bytes } from '@noir-lang/noir_wasm';
import { setup_generic_prover_and_verifier, create_proof, verify_proof, create_proof_with_witness } from '@noir-lang/barretenberg/dest/client_proofs';
import path from 'path';
import { readFileSync } from 'fs';

function path_to_uint8array(path: string) {
    let buffer = readFileSync(path);
    return new Uint8Array(buffer);
}

async function generateProof() {
    let acirByteArray = path_to_uint8array(path.resolve(__dirname, `../circuits/build/${process.argv[2]}.acir`));
    let acir = acir_from_bytes(acirByteArray);

    let abi = {
        nullifier : 666,
        secret : 420,
        nullifierHash : "0x1b740f8850d8cedad82a1b6fe8002d742625ed8c2a306ffd33b8624a708029ee",
        recipient : "0xD2927a91570146218eD700566DF516d67C5ECFAB"
    }

    console.log("Setting up generic prover and verifier...");
    let [prover, verifier] = await setup_generic_prover_and_verifier(acir);
    console.log("Creating proof...");
    const proof = await create_proof(prover, acir, abi);
    console.log("Verifying proof...");
    const verified = await verify_proof(verifier, proof);

    console.log("Proof : ", proof.toString('hex'));
    console.log("Is the proof valid : ", verified);
}

generateProof().then(() => process.exit(0)).catch(console.log);