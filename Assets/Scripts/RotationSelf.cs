using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotationSelf : MonoBehaviour
{
  [SerializeField] float rotationSpeed = 10f;
  [SerializeField] GameObject a,b,c,d,e,f;
  void Start()
  {
    Debug.Log("Yarrak.");
  }

  // Update is called once per frame
  void Update()
  {
    a.transform.Rotate(Time.deltaTime * rotationSpeed , 0.0f, 0.0f, Space.Self);
    b.transform.Rotate(Time.deltaTime * rotationSpeed , 0.0f, Time.deltaTime * -rotationSpeed, Space.Self); 
    c.transform.Rotate(0f, Time.deltaTime * rotationSpeed, 0.0f, Space.Self);
    d.transform.Rotate(Time.deltaTime * -rotationSpeed , Time.deltaTime * rotationSpeed, 0.0f, Space.Self);
    e.transform.Rotate(Time.deltaTime * -rotationSpeed , Time.deltaTime * -rotationSpeed, Time.deltaTime * -rotationSpeed, Space.Self);
    f.transform.Rotate(Time.deltaTime * rotationSpeed , Time.deltaTime * rotationSpeed, Time.deltaTime * rotationSpeed, Space.Self);
  }
}
