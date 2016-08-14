import React from 'react'
import RefreshIndicator from 'material-ui/RefreshIndicator';

class Loading extends React.Component {

  constructor(props) {
    super(props);
  }
  
  render() {
    
    let refresh =  {
      display: 'inline-block',
      position: 'relative',
    };
    
    return (
      <div className='center'>
        <RefreshIndicator
          size={40}
          left={0}
          top={0}
          style={refresh}
          status="loading"
        />
      </div>
    )
  }
}

module.exports = Loading
