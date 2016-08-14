import React from 'react'

class Error extends React.Component {
  
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div>
        <div className='container'>
          <h1>This is the error page!</h1>
        </div>
      </div>
    )
  }
}

module.exports = Error
