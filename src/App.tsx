import FlutterCanvas from "./FlutterCanvas";
import "./App.css";

function App() {
  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        overflow: "hidden",
      }}
    >
      <FlutterCanvas />
    </div>
  );
}

export default App;
