const { useState } = React;

export default function Box({ id, children }) {
  const [visible, setVisible] = useState(false);
  return (
    <div id={id}>
      <button type="button" onClick={() => setVisible(!visible)}>
        {visible ? 'Hide' : 'Show'}
      </button>
      {visible && children}
    </div>
  );
}
