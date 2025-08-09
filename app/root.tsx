// example.tsx

type Props = {
    name: string;
};

function Hello({ name }: Props) {
    return <h1>Hello, {name}!</h1>;
}

export default Hello;