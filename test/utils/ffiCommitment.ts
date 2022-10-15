import { BarretenbergWasm } from '@noir-lang/barretenberg/dest/wasm';
import { SinglePedersen } from '@noir-lang/barretenberg/dest/crypto/pedersen';

const toFixedHex = (number: number, pad0x: boolean, length = 32) => {
    let hexString = number.toString(16).padStart(length * 2, '0');
    return (pad0x ? `0x` + hexString : hexString);
}

async function generateCommitment() {
    let barretenberg = await BarretenbergWasm.new();
    await barretenberg.init()
    let pedersen = new SinglePedersen(barretenberg);

    let nullifier = Buffer.from(toFixedHex(parseInt(process.argv[2]), false), 'hex');
    let secret = Buffer.from(toFixedHex(parseInt(process.argv[3]), false), 'hex');

    let commitment = pedersen.compressInputs([nullifier, secret]);
    let nullifierHash = pedersen.compressInputs([nullifier]);

    console.log(commitment.toString('hex')+nullifierHash.toString('hex'));
}

generateCommitment().then(() => process.exit(0)).catch(console.log);